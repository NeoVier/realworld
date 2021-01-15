import {
  AfterLoad,
  Column,
  CreateDateColumn,
  Entity,
  JoinTable,
  ManyToMany,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { string_to_slug } from "../utils/stringToSlug";
import Tag from "./Tag";
import User from "./User";

@Entity()
class Article {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  slug: string;

  @Column()
  description: string;

  @Column()
  body: string;

  @ManyToMany(() => Tag, (tag) => tag.articles)
  @JoinTable()
  tagList: Tag[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.articles)
  author: User;

  @ManyToMany(() => User, (user) => user.favorited)
  @JoinTable()
  favorited: User[];

  favoriteCount: number;

  @AfterLoad()
  updateFavoriteCount() {
    this.favoriteCount = this.favorited.length;
  }

  @AfterLoad()
  updateSlug() {
    this.slug = string_to_slug(this.title);
  }
}

export default Article;
